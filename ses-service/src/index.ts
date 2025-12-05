import { sendEmail } from "./ses";

async function main() {
  console.log("Sending SES email using IRSA");
  await sendEmail({
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
