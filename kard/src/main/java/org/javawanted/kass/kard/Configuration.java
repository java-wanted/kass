/*
 * Configuration of Kafka Reader
 */

package org.javawanted.kass.kard;

class Configuration {
    public final String BOOTSTRAP_SERVERS;
    public final String SECURITY_SSL;
    public final String SSL_TRUSTSTORE_LOCATION;
    public final String SSL_TRUSTSTORE_PASSWORD;

    public Configuration() {
        this.BOOTSTRAP_SERVERS = System.getenv("BOOTSTRAP_SERVERS");
        this.SECURITY_SSL = System.getenv("SECURITY_SSL");
        this.SSL_TRUSTSTORE_LOCATION = System.getenv("SSL_TRUSTSTORE_LOCATION");
        this.SSL_TRUSTSTORE_PASSWORD = System.getenv("SSL_TRUSTSTORE_PASSWORD");
    }
}
