import { backendApiBaseUrl } from "./appsettings.json";

export const appSettings = {
    backendApiBaseUrl
}

export * from "./models/User";
export * from "./models/Chat";
export * from "./services/UserService";
export * from "./services/ChatService";