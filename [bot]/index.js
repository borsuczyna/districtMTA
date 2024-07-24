import 'dotenv/config';
import Bot from './structures/client.js';
import * as Config from './utils/config.js';

const client = new Bot(Config);
client.start();