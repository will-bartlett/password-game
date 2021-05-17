export interface User {
    username: string;
}

export interface UserWithSecurityAttrs extends User {
    passwordHash: string,
    securityAnswers: { [key: string]: string };
}