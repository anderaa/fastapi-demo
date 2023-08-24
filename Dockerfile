# Use an official Python runtime as a base image
FROM python:3.9.17-alpine3.18

# Set the working directory inside the container
WORKDIR /fastapi-demo

# Copy the requirements file into the container at /app
COPY requirements.txt /fastapi-demo/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application's code into the container
COPY . /fastapi-demo/

# Expose the port that your FastAPI app will listen on
EXPOSE 8000

# Define the command to run your FastAPI app
CMD ["uvicorn", "app.main:my_app", "--host", "0.0.0.0", "--port", "8000"]