/*
 * Configuration of Kafka Writer
 */

package org.javawanted.kass.kawr;

class Configuration {
    public final String BOOTSTRAP_SERVERS;

    public Configuration() {
        this.BOOTSTRAP_SERVERS = System.getenv("BOOTSTRAP_SERVERS");
    }
}
