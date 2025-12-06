export interface ValkeyConfig {
  host: string;
  port: number;
  password: string;
  useTls: boolean;
  keyPrefix?: string;
}

export const config: ValkeyConfig = {
  host: process.env.VALKEY_HOST ?? "localhost",
  port: Number(process.env.PORT) ?? 6379,
  password: process.env.PASSWORD ?? "",
  useTls: Boolean(process.env.USE_TLS) ?? false,
  keyPrefix: process.env.PREFIX ?? "",
};
