import { URL, fileURLToPath, pathToFileURL } from 'node:url';
import { promisify } from 'node:util';
import path from 'node:path';
import { glob } from 'glob';

import Command from './command.js';
import Event from './event.js';

const globber = promisify(glob);

export default class Util {
    constructor(client) {
        this.client = client;
    }

    isClass(input) {
		return typeof input === 'function' &&
            typeof input.prototype === 'object' &&
            input.toString().slice(0, 5) === 'class';
	}

    get directory() {
		const main = fileURLToPath(new URL('../index.js', import.meta.url));
		return `${path.dirname(main) + path.sep}`.replace(/\\/g, '/');
	}

    async loadCommands() {
        console.log("kupa")

        return globber(`${this.directory}commands/*.js`).then(async(commands) => {
            for (const commandFile of commands) {
                const { name } = path.parse(commandFile);
                const { default: File } = await import(pathToFileURL(commandFile));
                if (!this.isClass(File)) return;

                const command = new File(this.client, name.toLowerCase());
                if (!(command instanceof Command)) return;

                this.client.commands.set(command.name.join('-'), command);
            }
        });
    }

    async loadEvents() {
        console.log("kupa")
		return globber(`${this.directory}events/*.js`).then(async (events) => {
			for (const eventFile of events) {
				const { name } = path.parse(eventFile);
				const { default: File } = await import(pathToFileURL(eventFile));
				if (!this.isClass(File)) return;

				const event = new File(this.client, name);
				if (!(event instanceof Event)) return;
			    
                this.client.events.set(event.name, event);
				event.emitter[event.type](event.name, (...args) => event.run(...args));
			}
		});
	}
}