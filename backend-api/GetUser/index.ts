import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { UserAsTableEntity, UserFromTableEntity } from "../models/UserAsTableEntity";

const getUser: AzureFunction = async (context: Context, req: HttpRequest, userEntity: UserAsTableEntity) => {
    if(!userEntity) {
        context.res = {
            status: 404,
            body: "User not found"
        };
        return;
    }

    context.res = {
        status: 200,
        body: UserFromTableEntity(userEntity)
    };
};

export default getUser;