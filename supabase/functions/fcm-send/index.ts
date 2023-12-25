import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
// import { corsHeaders } from '../_shared/cors.ts'
import {
  getToken,
  GoogleAuth,
} from "https://deno.land/x/googlejwtsa@v0.1.8/mod.ts";

Deno.serve(async (req) => {
  const fcmUrl =
    "https://fcm.googleapis.com/v1/projects/ktp-flutter-chat-demo/messages:send";

    const googleServiceAccountCredentials = Deno.env.get(CLIENT_SECRET);
    
    const googleAuthOptions = {
      scope: ["https://www.googleapis.com/auth/firebase.messaging"],
    };
  
    const jwt: GoogleAuth = await getToken(
      JSON.stringify(googleServiceAccountCredentials),
      googleAuthOptions,
    );

  
  // Get notification body
  const body = await req.text();

  let senderId, chatId, text;
  try {
    const json = JSON.parse(body);
    console.log(json)
    senderId = json.record.senderId;
    chatId = json.record.chatId;
    text = json.record.text;
  } catch (error) {
    console.error("Error parsing JSON:", error);
    return new Response("Error parsing JSON", { status: 400 });
  }

  let fcm_token, sender_name;
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    let result = await supabaseClient.from('users').select().eq("id", senderId)
    if (result.error) throw result.error
    console.log(result)
    sender_name = result.data[0].name

    result = await supabaseClient.from('usersChats').select().eq("chatId", chatId).neq("userId", senderId)
    if (result.error) throw result.error
    console.log(result)
    const receiverId = result.data[0].userId

    result = await supabaseClient.from('users').select().eq("id", receiverId)
    if (result.error) throw result.error
    console.log(result)
    fcm_token = result.data[0].fcm_token
  } catch (error) {
    console.log(error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }

  const payload = {
    message: {
      token: fcm_token,
      notification: {
        title: sender_name,
        body: text,
      },
    },
  };

  const headers = {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${jwt.access_token}`,
  };

  console.log(payload)
  const response = await fetch(fcmUrl, {
    method: "POST",
    headers: headers,
    body: JSON.stringify(payload),
  });

  if (response.ok) {
    const data = await response.json();
    return new Response(
      JSON.stringify(["OK", data]),
      { headers: { "Content-Type": "application/json" } },
    );
  } else {
    console.error("Error sending FCM:", response);
    const data = {
      message: `Could not send notification`,
    };
    return new Response(
      JSON.stringify(["FAIL", data]),
      { status: 409, headers: { "Content-Type": "application/json" } },
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/fcm-send' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
