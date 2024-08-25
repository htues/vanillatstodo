import './index.css';
import { Todo } from './types';

const todos: Todo[] = [
  { id: 1, text: 'Wake-up', completed: false },
  { id: 2, text: 'Take a bath', completed: false },
  { id: 3, text: 'Say your prayers', completed: false }
];
let nextId = 4;

const todoList = document.getElementById('todo-list')!;
const newTodoInput = document.getElementById('new-todo') as HTMLInputElement;
const addTodoButton = document.getElementById('add-todo')!;
const heading = document.querySelector('h3.heading')!; // Select the h3 element

addTodoButton.addEventListener('click', (event) => {
  event.preventDefault(); 
  const text = newTodoInput.value.trim();
  if (text) {
    addTodo({ id: nextId++, text, completed: false });
    newTodoInput.value = '';
  }
});

function addTodo(todo: Todo) {
  todos.push(todo);
  renderTodos();
}

function toggleComplete(id: number) {
  const todo = todos.find(todo => todo.id === id);
  if (todo) {
    todo.completed = !todo.completed;
    renderTodos();
  }
}

function renderTodos() {
  todoList.innerHTML = '';
  todos.forEach(todo => {
    const li = document.createElement('li');
    li.textContent = todo.text;
    li.className = todo.completed ? 'completed' : '';
    li.addEventListener('click', () => toggleComplete(todo.id));
    todoList.appendChild(li);
  });

  const todoCount = document.getElementById('todo-count')!;
  if (todos.length === 0) {
    todoCount.textContent = "You don't have any tasks";
  } else {
    const completedCount = todos.filter(todo => todo.completed).length;
    todoCount.textContent = `You have ${todos.length} task(s), ${completedCount} completed`;
  }
}

renderTodos();