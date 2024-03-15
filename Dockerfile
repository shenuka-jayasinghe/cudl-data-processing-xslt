# Use Alpine Linux as base image
FROM alpine:latest

# Define environment variables for Saxon version and Ant version
ENV SAXON_VERSION 9-9-1-8J
ENV ANT_VERSION 1.10.13

# Install necessary packages
RUN apk add --update --no-cache \
    openjdk11 \
    wget \
    tar \
    unzip

# Set up necessary directories
WORKDIR /opt

# Download and install Apache Ant
RUN wget -q "https://downloads.apache.org//ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" \
    && tar -xzf apache-ant-$ANT_VERSION-bin.tar.gz \
    && rm apache-ant-$ANT_VERSION-bin.tar.gz \
    && mv apache-ant-$ANT_VERSION /opt/apache-ant

# Set up environment variables for Ant
ENV ANT_HOME /opt/apache-ant
ENV PATH $ANT_HOME/bin:$PATH

# Download and install Saxon Javadoc JAR
RUN wget -q "https://downloads.saxonica.com/SaxonJ/PE/9/SaxonPE$SAXON_VERSION.zip" \
    && unzip -q SaxonPE$SAXON_VERSION.zip \
    && rm SaxonPE$SAXON_VERSION.zip \
    && mv saxon9pe.jar /opt/apache-ant/lib/saxon9pe.jar

# Set up environment variables for Saxon
ENV SAXON_JAVADOC /opt/Saxon-HE-$SAXON_VERSION-javadoc.jar
ENV CLASSPATH="/opt/apache-ant/lib/saxon9pe.jar"
# ENV CLASSPATH="/opt/apache-ant/lib/Saxon-HE-$SAXON_VERSION-javadoc.jar"

# Download and install ant-contrib
RUN wget -q "https://repo1.maven.org/maven2/ant-contrib/ant-contrib/1.0b3/ant-contrib-1.0b3.jar" -O /opt/apache-ant/lib/ant-contrib-1.0b3.jar

# Copy your project files into the container
COPY . .

# Define default command
CMD ["sh"]


# =====================================================================

# To test, run the following commands in terminal
# 1. Shell in to the image using: 
# sudo docker run -it --rm cudl-xslt:0.0.3
# 2. then link sample TEI data directory to the data XSLT data processing directory and build process using ANT:
# ln -s dl-data-samples/source-data/data/items/data/tei/MS-TEST-ITEM-00001/ data
# ant -buildfile ./bin/build.xml "json"