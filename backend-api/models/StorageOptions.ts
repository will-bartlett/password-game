import { OperationOptions } from "@azure/core-client"

export const DefaultOperationOptions: OperationOptions = {
    requestOptions: {
        allowInsecureConnection: process.env.NODE_ENV !== 'production'
    }
}