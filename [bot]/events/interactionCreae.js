export default class extends Event {
	constructor(...args) {
		super(...args, {
			name: 'interactionCreate',
			once: false
		});
	}

    async run(interaction) {
        if (!interaction.isChatInputCommand() && !interaction.isContextMenuCommand()) return;

		const command = this.client.interactions.get(this.getCommandName(interaction));
		if (command) {
            try {
                await command.run(interaction);
            } catch (error) {
                console.log(error);
            }
        }
    }
}