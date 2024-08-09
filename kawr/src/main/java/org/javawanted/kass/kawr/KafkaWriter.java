/*
 * The Kafka Writer Program
 */
package org.javawanted.kass.kawr;

import java.io.Closeable;
import java.util.Properties;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

/*
 * A class to write messages into a Kafka Topic
 */
class KafkaWriter implements Closeable {
    String topic;
    KafkaProducer<String, String> producer;

    /*
     * Initialise the self
     *
     * topic      the topic to send messages to
     * properties the properties of the connection
     */
    public KafkaWriter(String topic, Properties properties) {
        this.topic = topic;
        this.producer = new KafkaProducer<String, String>(properties);
    }

    public void close() {
        if (this.producer != null) {
            this.producer.close();
            this.producer = null;
        }
    }

    public void send(String message) {
        var rec = new ProducerRecord<String, String>(this.topic, message);

        try {
            System.out.printf("Sending '%s'...\n", message);
            producer.send(rec).get();
        } catch (Exception e) {
            System.out.printf(
                "Failed to send '%s': %s\n", message, e.getMessage()
            );
            System.exit(1);
        }
    }

    public static void main(String []argv) {
        var conf = new Configuration();
        var prop = new Properties();

        prop.put(
            "key.serializer",
            "org.apache.kafka.common.serialization.StringSerializer"
        );
        prop.put(
            "value.serializer",
            "org.apache.kafka.common.serialization.StringSerializer"
        );
        prop.put("bootstrap.servers", conf.BOOTSTRAP_SERVERS);

        if (conf.SECURITY_SSL.equals("yes")) {
            prop.put("security.protocol", "SSL");
            prop.put("ssl.truststore.location", conf.SSL_TRUSTSTORE_LOCATION);
            prop.put("ssl.truststore.password", conf.SSL_TRUSTSTORE_PASSWORD);
        }

        var topic = "1";
        String []messages = {"1", "2"};

        try (var writer = new KafkaWriter(topic, prop)) {
            for (var m : messages) {
                writer.send(m);
            }
        }
    }
}
