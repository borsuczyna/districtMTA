import Command from '../structures/command.js';

export default class extends Command {
	constructor(...args) {
		super(...args, {
			name: ['test'],
			description: 'test'
		});
	}

	async run(interaction) {
		return interaction.reply({ content: 'test' });
	}
}