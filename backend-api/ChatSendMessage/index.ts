import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { ChatServiceMethod, ChatMessageArgs } from "@pwdgame/shared";

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<any> {
    const args = req.body.args as ChatMessageArgs;
    
    context.res = {
        status: 201
    };

    return {
        target: ChatServiceMethod.SendMessage,
        arguments: args
    };
};

export default httpTrigger;