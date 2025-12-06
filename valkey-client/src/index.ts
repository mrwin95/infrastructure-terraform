import { pingValkey, demoSetGet } from "./valkey-client";

async function main() {
  console.log(`Start Valkey test`);

  try {
    await pingValkey();
    await demoSetGet();
  } catch (err) {
    console.error(`Failed talking to Vakley: `, err);
    process.exitCode = 1;
    return;
  }

  console.log("Done");
  process.exit(0);
}

main().catch((err) => {
  console.error("Unexpected error: ", err);
  process.exit(1);
});
