import { Client, Collection, Partials, GatewayIntentBits, PermissionsBitField } from 'discord.js';
import Util from './util.js';

export default class Bot extends Client {
    constructor(options = {}) {
        super({
            intents: [
				GatewayIntentBits.Guilds,
				GatewayIntentBits.GuildMembers,
				GatewayIntentBits.GuildPresences,
				GatewayIntentBits.GuildMessages,
				GatewayIntentBits.MessageContent
			],
			partials: [
				Partials.Channel
			],
			allowedMentions: {
				parse: ['users', 'roles'],
				repliedUser: false
			}
        })

        this.validate(options);

        this.commands = new Collection();
        this.events = new Collection();
        this.utils = new Util(this);
    }

    validate(options) {
		this.token = options.token;
	}

    async start(token = this.token) {
        await this.utils.loadCommands();
        await this.utils.loadEvents();

        super.login(token);
    }
}