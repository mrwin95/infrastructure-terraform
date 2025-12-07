"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendEmail = sendEmail;
const client_sesv2_1 = require("@aws-sdk/client-sesv2");
const aws_1 = require("./aws");
async function sendEmail(input) {
    const cmd = new client_sesv2_1.SendEmailCommand({
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
    return aws_1.sesClient.send(cmd);
}
//# sourceMappingURL=ses.js.map