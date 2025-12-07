"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sesClient = void 0;
const client_sesv2_1 = require("@aws-sdk/client-sesv2");
exports.sesClient = new client_sesv2_1.SESv2Client({
    region: "ap-northeast-1",
});
//# sourceMappingURL=aws.js.map