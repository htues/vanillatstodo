import './index.css'

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-6 rounded-lg shadow-lg text-center">
      <h1 class="text-4xl font-bold mb-4">Hello World</h1>
      <p class="text-white font-bold bg-blue-500 p-6 rounded-2xl">
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      </p>
    </div>
  </div>
`
