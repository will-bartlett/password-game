import { HubConnection, HubConnectionBuilder } from "@microsoft/signalr";
import { ChatMessage } from "../models/Chat";

export enum ChatServiceMethod {
    SendMessage = "send"
}

export type ChatMessageArgs = [ ChatMessage ];

export type ChatListener = (...args: ChatMessageArgs) => void;

export class ChatService {
    private readonly connection: Promise<HubConnection>;
    private readonly listeners =  {} as { [id: string]: ChatListener }
    
    constructor(private readonly apiBaseUrl: string) {
        const _conn = new HubConnectionBuilder()
            .withUrl(`${apiBaseUrl}api/chat`)
            .build();

        _conn.on(ChatServiceMethod.SendMessage,
            (...args) => this.onMessage(...(args as ChatMessageArgs)));

        this.connection = _conn.start().then(() => _conn);
    }

    public async sendMessage(...args: ChatMessageArgs) {
        await this.connection;
        const resp = await fetch(`${this.apiBaseUrl}api/chat/sendmessage`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ args })
        });
        if(!resp.ok) {
            throw new Error("Failed to send chat message.");
        }
    }

    public async dispose() {
        await (await this.connection).stop();
    }

    public addMessageListener(listener: ChatListener) {
        const id = new Date().getTime().toString();
        this.listeners[id] = listener;
        return id;
    }

    public removeMessageListener(listenerId: string) {
        if(this.listeners[listenerId]) {
            delete this.listeners[listenerId];
        }
    }

    private onMessage(...args: ChatMessageArgs) {
        Object.keys(this.listeners)
            .forEach(id => this.listeners[id](...args));
    }
}