# Use an official Ruby runtime as a parent image
FROM ruby:3.2.2

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install any needed gems specified in Gemfile
RUN bundle install

# Expose port 3000 to allow external access
EXPOSE 3000

# Define the command to run the bot
CMD ["ruby", "livegram_bot.rb"]
