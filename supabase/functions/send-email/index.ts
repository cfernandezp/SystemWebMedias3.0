// Edge Function: send-email
// Purpose: Send emails via SMTP to Inbucket (local testing)
// Called by: PostgreSQL Database Functions via pg_net.http_post

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface EmailRequest {
  to: string;
  toName: string;
  subject: string;
  html: string;
  from?: string;
  fromName?: string;
}

async function sendSMTP(to: string, from: string, subject: string, html: string): Promise<void> {
  const conn = await Deno.connect({ hostname: "inbucket", port: 2500 });
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();

  try {
    // Read greeting
    const buffer = new Uint8Array(1024);
    await conn.read(buffer);

    // HELO
    await conn.write(encoder.encode("HELO localhost\r\n"));
    await conn.read(buffer);

    // MAIL FROM
    await conn.write(encoder.encode(`MAIL FROM:<${from}>\r\n`));
    await conn.read(buffer);

    // RCPT TO
    await conn.write(encoder.encode(`RCPT TO:<${to}>\r\n`));
    await conn.read(buffer);

    // DATA
    await conn.write(encoder.encode("DATA\r\n"));
    await conn.read(buffer);

    // Email content
    const message = `From: ${from}\r\nTo: ${to}\r\nSubject: ${subject}\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n${html}\r\n.\r\n`;
    await conn.write(encoder.encode(message));
    await conn.read(buffer);

    // QUIT
    await conn.write(encoder.encode("QUIT\r\n"));

  } finally {
    conn.close();
  }
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { to, toName, subject, html, from, fromName }: EmailRequest = await req.json();

    // Validate required fields
    if (!to || !subject || !html) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: to, subject, html' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const fromEmail = from || "noreply@hiltex.com";

    // Send email via raw SMTP
    await sendSMTP(to, fromEmail, subject, html);

    return new Response(
      JSON.stringify({ success: true, message: 'Email sent successfully' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error sending email:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
