import { MongoClient, Db } from 'mongodb';

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/msar_elnor';
const options = {};

let client: MongoClient;
let clientPromise: Promise<MongoClient>;

declare global {
  // eslint-disable-next-line no-var
  var _mongoClientPromise: Promise<MongoClient> | undefined;
}

export const isMongoConfigured = (): boolean => {
  return !!process.env.MONGODB_URI;
};

if (process.env.NODE_ENV === 'development') {
  // In development mode, use a global variable so that the value
  // is preserved across module reloads caused by HMR (Hot Module Replacement).
  if (!global._mongoClientPromise) {
    client = new MongoClient(uri, options);
    global._mongoClientPromise = client.connect().catch((err) => {
      console.warn('MongoDB local connection notice:', err.message);
      return client;
    });
  }
  clientPromise = global._mongoClientPromise;
} else {
  // In production mode, it's best to not use a global variable.
  client = new MongoClient(uri, options);
  clientPromise = client.connect();
}

export default clientPromise;

export async function getDatabase(dbName = 'msar_elnor'): Promise<Db | null> {
  try {
    const client = await clientPromise;
    return client.db(dbName);
  } catch (error) {
    console.warn('Failed to connect to MongoDB, falling back to local memory store:', error);
    return null;
  }
}
