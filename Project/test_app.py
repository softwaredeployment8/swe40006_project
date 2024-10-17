import pytest
from flask import url_for
import app  

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_index(client):
    """Test the index route."""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Sample Todo' in response.data  # Check if the sample todo is in the response

def test_add_todo(client):
    """Test adding a new todo item."""
    response = client.post('/add', data={'todo': 'New Todo'})
    assert response.status_code == 302  # Check for redirect
    assert b'New Todo' in client.get('/').data  # Ensure the new todo appears on the index page

def test_edit_todo(client):
    """Test editing an existing todo item."""
    client.post('/add', data={'todo': 'Todo to Edit'})
    response = client.get('/edit/0')  # Edit the first todo
    assert response.status_code == 200
    assert b'Todo to Edit' in response.data  # Ensure the edit page contains the correct todo

    # Submit the edit
    response = client.post('/edit/0', data={'todo': 'Edited Todo'})
    assert response.status_code == 302  # Check for redirect
    assert b'Edited Todo' in client.get('/').data  # Ensure the edited todo appears on the index page

def test_check_todo(client):
    """Test checking off a todo item."""
    client.post('/add', data={'todo': 'Todo to Check'})
    response = client.get('/check/0')  # Check the first todo
    assert response.status_code == 302  # Check for redirect

    # Verify the todo is marked as done
    response = client.get('/')
    assert b'done' in response.data  # Adjust this based on how you indicate done tasks in your template

def test_delete_todo(client):
    """Test deleting a todo item."""
    client.post('/add', data={'todo': 'Todo to Delete'})
    response = client.get('/delete/0')  # Delete the first todo
    assert response.status_code == 302  # Check for redirect
    response = client.get('/')
    assert b'Todo to Delete' not in response.data  # Ensure the todo no longer appears
