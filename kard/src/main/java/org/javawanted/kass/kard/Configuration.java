/*
 * Configuration of Kafka Reader
 */

package org.javawanted.kass.kard;

class Configuration {
    public final String BOOTSTRAP_SERVERS;

    public Configuration() {
        this.BOOTSTRAP_SERVERS = System.getenv("BOOTSTRAP_SERVERS");
    }
}
