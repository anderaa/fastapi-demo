import httpx
from fastapi.testclient import TestClient
from main import my_app


client = TestClient(my_app)


def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World!!!"}

def another_test():
    assert False