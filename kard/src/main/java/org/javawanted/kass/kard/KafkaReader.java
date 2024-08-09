/*
 * The Kafka Reader Program
 */
package org.javawanted.kass.kard;

import java.util.Arrays;
import java.util.Properties;
import java.time.Duration;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;

/*
 * A class to read messages from a Kafka Topic
 */
class KafkaReader {
    String topic;
    KafkaConsumer<String, String> consumer;

    /*
     * Initialise the self
     *
     * topic      the topic to read messages from
     * properties the properties of the connection
     */
    public KafkaReader(String topic, Properties properties) {
        this.topic = topic;
        this.consumer = new KafkaConsumer<String, String>(properties);
    }

    public void run() {
        this.consumer.subscribe(Arrays.asList(this.topic));

        while (true) {
            if (this.recv() == 0) {
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                }
            }
        }
    }

    public int recv() {
        try {
            ConsumerRecords<String, String> recs = consumer.poll(
                Duration.ZERO
            );

            for (var rec : recs) {
                System.out.printf(
                    "KafkaReader: read '%s'\n", rec.value()
                );
            }

            return recs.count();
        } catch (Exception e) {
            System.out.printf(
                "KafkaReader: failed fot read: %s\n", e.getMessage()
            );
            System.exit(1);

            return 0;
        }
    }

    public static void main(String []argv) {
        var conf = new Configuration();
        var prop = new Properties();

        prop.put("group.id", "1");
        prop.put(
            "key.deserializer",
            "org.apache.kafka.common.serialization.StringDeserializer"
        );
        prop.put(
            "value.deserializer",
            "org.apache.kafka.common.serialization.StringDeserializer"
        );
        prop.put("bootstrap.servers", conf.BOOTSTRAP_SERVERS);

        if (conf.SECURITY_SSL.equals("yes")) {
            prop.put("security.protocol", "SSL");
            prop.put("ssl.truststore.location", conf.SSL_TRUSTSTORE_LOCATION);
            prop.put("ssl.truststore.password", conf.SSL_TRUSTSTORE_PASSWORD);
        }

        var topic = "1";

        System.out.printf(
            "Reading messages from topic '%s'...\n", topic
        );

        new KafkaReader(topic, prop).run();
    }
}
