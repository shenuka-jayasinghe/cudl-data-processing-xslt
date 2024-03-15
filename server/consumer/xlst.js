const Kafka = require('node-rdkafka');


const consumer = new Kafka.KafkaConsumer({
    'group.id': 'kafka',
    'metadata.broker.list': 'localhost:9092',
  }, {});
  // Flowing mode
consumer.connect();

consumer.on('ready', () => {
    consumer.subscribe(['test']) //subscribe to topics
    consumer.consume();
    console.log('xlst consumer ready...')

}).on('data', (data) => {
    console.log(`received message: ${data.value.toString()}`)
})