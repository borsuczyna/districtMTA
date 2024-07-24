import { PermissionsBitField } from 'discord.js';

export default class Command {
	constructor(client, name, options = {}) {
		this.client = client;

		this.name = options.name || [name];
		this.description = options.description || '';
	}

	async run(interaction) {
		return;
	}
}