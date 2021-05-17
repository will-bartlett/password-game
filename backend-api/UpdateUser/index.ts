import { AzureFunction, Context, HttpRequest } from "@azure/functions";
import { TableClient } from "@azure/data-tables";
import { UserWithSecurityAttrs, UserToTableEntity } from "../models/UserAsTableEntity";
import { UserTableName, DefaultOperationOptions } from "../models/Settings";

const updateUser: AzureFunction = async (context: Context, req: HttpRequest) => {
    if (!isValidUser(req.body)) {
        context.res = {
            status: 400,
            body: "Invalid user object"
        };
        return;
    }

    const entity = UserToTableEntity(req.body);

    const tableClient = TableClient.fromConnectionString(
        process.env["StorageAccountConnectionString"], UserTableName);

    try {
        await tableClient.create(DefaultOperationOptions);
    } catch (err) {
        if (err.details?.odataError?.code !== "TableAlreadyExists") {
            throw err;
        }
    }

    await tableClient.upsertEntity(entity, "Merge", DefaultOperationOptions);

    context.res = {
        status: 204 // no content
    };
};

const isValidUser = (user: any): user is UserWithSecurityAttrs => {
    return user
        && typeof user.username === "string"
        && typeof user.passwordHash === "string"
        && (user as {}).hasOwnProperty("securityAnswers");
}

export default updateUser;