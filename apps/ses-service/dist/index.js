"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const ses_1 = require("./ses");
async function main() {
    console.log("Sending SES email using IRSA");
    await (0, ses_1.sendEmail)({
        from: "mrwin05@gmail.com",
        to: ["wincadevops@gmail.com"],
        subject: "Test",
        html: "<h1> Hello from EKS IRSA</h1>",
        text: "Hello from EKS",
    });
    console.log("Email sent");
}
main().catch((err) => {
    console.error("Error: ", err);
    process.exit(1);
});
//# sourceMappingURL=index.js.map