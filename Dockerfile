FROM docker.io/heartexlabs/label-studio:latest

# Railway provides PORT dynamically
ENV LABEL_STUDIO_HOST=${RAILWAY_PUBLIC_DOMAIN:+https://${RAILWAY_PUBLIC_DOMAIN}}
ENV DATA_DIR=/label-studio/data
ENV MEDIA_ROOT=/label-studio/data/media

# Create necessary directories
RUN mkdir -p /label-studio/data/media /label-studio/logs

# Set proper permissions for non-root container
USER root
RUN chown -R 1001:1001 /label-studio/data /label-studio/logs

USER 1001

# Use shell form to allow variable expansion
CMD label-studio start --host 0.0.0.0 --port ${PORT:-8080}