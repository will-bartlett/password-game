import { sha256 } from 'js-sha256'
import User from '../models/User'

interface UserWithSecurityAttrs extends User {
    passwordHash: string,
    securityAnswers: { [key: string]: string };
}

export default class UserService {

    public async clear() {
        localStorage.clear();
    }

    public async createUser(user: User, password: string, securityAnswers: { [key: string]: string }) {
        if (localStorage.getItem(this.makeUserStorageKey(user.username)) !== null) {
            throw new Error("That username is already taken.");
        }
        Object.keys(securityAnswers).forEach(k => securityAnswers[k] = this.hashValue(securityAnswers[k]));
        const userWithPass: UserWithSecurityAttrs = {
            ...user,
            passwordHash: this.hashValue(password),
            securityAnswers: securityAnswers
        }
        this.persistUser(userWithPass);
    }

    public async loginUser(username: string, password: string) {
        const user = await this.retrieveUser(username);
        if (!user || user.passwordHash !== this.hashValue(password)) {
            throw new Error("Invalid username or password!")
        }
        return user as User
    }

    public async getSecurityQuestions(): Promise<{ [key: string]: string }> {
        return {
            "favPet": "What is your pet's name?",
            "favFood": "What is your favorite food?",
            "birthplace": "What city were you born in?"
        };
    }

    public async verifySecurityAnswer(username: string, questionKey: string, questionAnswer: string) {
        const user = await this.retrieveUser(username);
        return user?.securityAnswers
            && user.securityAnswers[questionKey]
            && user.securityAnswers[questionKey] === this.hashValue(questionAnswer);
    }
    
    public async resetPassword(username: string, questionKey: string, questionAnswer: string, newPassword: string) {
        if(!await this.verifySecurityAnswer(username, questionKey, questionAnswer)) {
            throw new Error("Incorrect security question answer.");
        }
        const user = await this.retrieveUser(username);
        user!.passwordHash = this.hashValue(newPassword);
        await this.persistUser(user!);
        return user! as User;
    }

    private async persistUser(user: UserWithSecurityAttrs) {
        localStorage.setItem(
            this.makeUserStorageKey(user.username),
            JSON.stringify(user)
        )
    }

    private async retrieveUser(username: string) {
        const userJson = localStorage.getItem(this.makeUserStorageKey(username));
        return userJson ? JSON.parse(userJson) as UserWithSecurityAttrs : null;
    }

    private makeUserStorageKey(username: string) {
        return `userdata_${username}`
    }

    private hashValue(password: string) {
        return sha256(password)
    }
}