import { SendEmailCommand, SendEmailCommandOutput } from "@aws-sdk/client-sesv2";

import { sesClient } from "./aws";
export interface SendEmailInput {
  from: string;
  to: string[];
  subject: string;
  html?: string;
  text?: string;
}

export async function sendEmail(
  input: SendEmailInput
): Promise<SendEmailCommandOutput> {
  const cmd = new SendEmailCommand({
    FromEmailAddress: input.from,
    Destination: { ToAddresses: input.to },
    Content: {
      Simple: {
        Subject: { Data: input.subject },
        Body: {
          Html: input.html ? { Data: input.html } : undefined,
          Text: input.text ? { Data: input.text } : undefined,
        },
      },
    },
  });

  return sesClient.send(cmd);
}
