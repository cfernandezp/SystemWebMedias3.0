import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ResetPasswordRequest {
  token: string
  newPassword: string
  ipAddress?: string
}

interface ValidationResponse {
  success: boolean
  data?: {
    is_valid: boolean
    user_id: string
    expires_at: string
  }
  error?: {
    message: string
    hint: string
  }
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Crear cliente admin de Supabase
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Parse request
    const { token, newPassword, ipAddress }: ResetPasswordRequest = await req.json()

    // Validación de entrada
    if (!token || !newPassword) {
      return new Response(
        JSON.stringify({
          success: false,
          error: {
            message: 'Token y nueva contraseña son requeridos',
            hint: 'missing_params'
          }
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Validar fortaleza de contraseña (mínimo 8 caracteres)
    if (newPassword.length < 8) {
      return new Response(
        JSON.stringify({
          success: false,
          error: {
            message: 'La contraseña debe tener al menos 8 caracteres',
            hint: 'weak_password'
          }
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 1. Validar token usando la función RPC existente
    console.log('🔵 Validando token...')
    const { data: validationData, error: validationError } = await supabaseAdmin.rpc(
      'validate_reset_token',
      { p_token: token }
    )

    if (validationError) {
      console.error('❌ Error validando token:', validationError)
      return new Response(
        JSON.stringify({
          success: false,
          error: {
            message: 'Error al validar token',
            hint: 'validation_error'
          }
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const validation = validationData as ValidationResponse

    if (!validation?.success || !validation?.data?.is_valid) {
      const errorMessage = validation?.error?.message || 'Token inválido o expirado'
      const errorHint = validation?.error?.hint || 'invalid_token'

      return new Response(
        JSON.stringify({
          success: false,
          error: {
            message: errorMessage,
            hint: errorHint
          }
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const userId = validation.data.user_id

    console.log(`🔵 Token válido para usuario: ${userId}`)

    // 2. Actualizar password usando Supabase Admin API
    console.log('🔵 Actualizando contraseña...')
    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      userId,
      { password: newPassword }
    )

    if (updateError) {
      console.error('❌ Error actualizando contraseña:', updateError)
      return new Response(
        JSON.stringify({
          success: false,
          error: {
            message: updateError.message || 'Error al actualizar contraseña',
            hint: 'update_failed'
          }
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log('✅ Contraseña actualizada')

    // 3. Marcar token como usado
    console.log('🔵 Marcando token como usado...')
    const { error: markError } = await supabaseAdmin
      .from('password_recovery')
      .update({ used_at: new Date().toISOString() })
      .eq('token', token)

    if (markError) {
      console.error('⚠️ Error marcando token (no crítico):', markError)
    }

    // 4. Cerrar todas las sesiones activas del usuario
    console.log('🔵 Cerrando sesiones activas...')
    try {
      await supabaseAdmin.auth.admin.signOut(userId)
      console.log('✅ Sesiones cerradas')
    } catch (signOutError) {
      console.error('⚠️ Error cerrando sesiones (no crítico):', signOutError)
    }

    // 5. Registrar en auditoría
    console.log('🔵 Registrando auditoría...')
    const { error: auditError } = await supabaseAdmin
      .from('audit_log')
      .insert({
        user_id: userId,
        event_type: 'password_reset',
        ip_address: ipAddress || 'unknown',
        details: { method: 'edge_function' }
      })

    if (auditError) {
      console.error('⚠️ Error en auditoría (no crítico):', auditError)
    }

    console.log('✅ Reset de contraseña completado')

    // Respuesta exitosa
    return new Response(
      JSON.stringify({
        success: true,
        data: {
          message: 'Contraseña actualizada exitosamente. Por seguridad, todas las sesiones activas han sido cerradas.'
        }
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('❌ Error inesperado:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: {
          message: error instanceof Error ? error.message : 'Error interno del servidor',
          hint: 'internal_error'
        }
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
