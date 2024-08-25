import './index.css';
import { Todo } from './types';

const todos: Todo[] = [];
let nextId = 1;

const todoList = document.getElementById('todo-list')!;
const newTodoInput = document.getElementById('new-todo') as HTMLInputElement;
const addTodoButton = document.getElementById('add-todo')!;
const heading = document.querySelector('h3.heading')!; // Select the h3 element

console.log('Heading element:', heading);
console.log('Heading classes:', heading.className);

addTodoButton.addEventListener('click', () => {
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
}