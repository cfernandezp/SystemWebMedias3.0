#!/bin/bash
# Script de prueba para Edge Function reset-password
# HU-004: Recuperar Contraseña

echo "========================================="
echo "TEST EDGE FUNCTION: reset-password"
echo "========================================="

# Variables de configuración
FUNCTION_URL="http://localhost:54321/functions/v1/reset-password"

# Test 1: Validación - Token vacío
echo ""
echo "TEST 1: Token vacío (debe fallar con missing_params)"
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "",
    "newPassword": "NewPassword123!"
  }' | jq '.'

# Test 2: Validación - Password corta
echo ""
echo "TEST 2: Password < 8 caracteres (debe fallar con weak_password)"
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "fake-token-for-testing",
    "newPassword": "Pass1"
  }' | jq '.'

# Test 3: Token inválido
echo ""
echo "TEST 3: Token inválido (debe fallar con invalid_token)"
curl -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "invalid-token-xyz",
    "newPassword": "NewPassword123!",
    "ipAddress": "127.0.0.1"
  }' | jq '.'

echo ""
echo "========================================="
echo "TESTS COMPLETADOS"
echo "========================================="
echo ""
echo "NOTAS:"
echo "- Para test completo necesitas un token válido de password_recovery"
echo "- Ejecuta: SELECT * FROM password_recovery ORDER BY created_at DESC LIMIT 1;"
echo "- Usa el token obtenido para hacer test real"
echo ""
