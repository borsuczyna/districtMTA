import Event from '../structures/event.js';

export default class extends Event {
    constructor(...args) {
        super(...args, {
            name: 'ready',
            once: true
        });
    }

    async run() {
        console.log(`Logged in as ${this.client.user.tag}`);
    }
}