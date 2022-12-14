module.exports = {
	mode: 'jit',
	content: [
		'./../lib/**/*.ex',
		'./../lib/**/*.leex',
		'./../lib/**/*.heex',
		'./../lib/**/*.lexs',
		'./../lib/**/*.exs',
		'./../lib/**/*.eex',
		'./js/**/*.js'
	],
	theme: {
		extend: {},
	},
	variants: {
		extend: {},
	},
	plugins: [require('daisyui')],
};
