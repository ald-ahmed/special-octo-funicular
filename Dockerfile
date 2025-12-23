# Start from the code-server Alpine base image
FROM codercom/code-server:4.107.0-39

# Install unzip + rclone (support for remote filesystem) as root
USER root
RUN apk add --no-cache unzip bash curl
RUN curl https://rclone.org/install.sh | bash

# Switch back to coder user
USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# You can add custom software and dependencies for your environment below
# -----------

# Configure Open VSX marketplace for extensions
ENV SERVICE_URL=https://open-vsx.org/vscode/gallery
ENV ITEM_URL=https://open-vsx.org/vscode/item
ENV CS_DISABLE_GETTING_STARTED_OVERRIDE=true
# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension bradlc.vscode-tailwindcss
RUN code-server --install-extension ms-toolsai.jupyter
# Install apk packages:
# RUN apk add --no-cache <package-name>

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/home/coder/.bun/bin:${PATH}"

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
