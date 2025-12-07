import { SendEmailCommandOutput } from "@aws-sdk/client-sesv2";
export interface SendEmailInput {
    from: string;
    to: string[];
    subject: string;
    html?: string;
    text?: string;
}
export declare function sendEmail(input: SendEmailInput): Promise<SendEmailCommandOutput>;
//# sourceMappingURL=ses.d.ts.map