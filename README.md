![landing](https://github.com/weblab-notebook/website/blob/8be6df198faa501a181b7e963234a56e9d416be3/static/landing.svg)


# Weblab

[Weblab](https://www.weblab.ai) lets you write and evaluate Javascript in an interactive notebook. It gives you a great environment to build Machine learning and Data Science applications.

# Documentation

You can find the documentation at [www.weblab.ai/documentation](https://www.weblab.ai/documentation).

# Building

Firstly, install all dependencies.
```
npm install
```
Compile Rescript source files.
```
npm run re:build
```
Build website with Gatsby.
```
npm run build
```
# Contribution

If you are interested in the project you are welcome to contribute. So far the whole project is written in [Rescript](https://rescript-lang.org/) but it could be extended with Typescript.

The Website is build with [React](https://reactjs.org/) and built with [Gatsby](https://www.gatsbyjs.com/).

The main code is inside the **`/src`** directory. Inside the the **`src`** directory the code is structured as follows:

    .
    ├── assets
    ├── bindings
    ├── components
    ├── notebooks
    ├── pages
    ├── pagesComponents
    ├── service
    ├── styles

- **`/assets`**: Contains all files that are not code files like images, etc.

- **`/bindings`**: Bindings to Javascript libraries

- **`/components`**: Contains the components that build up the website. For each compenent there is a `ComponentName.res`-file that defines the React component. Additionally there can be a `ComponentNameBase.res`-file that defines types, reducers and other functions related to that component.

- **`/notebooks`**: Contains the .ijsnb notebooks that are used accross the website

- **`/pages`**: Defines the entry points for Gatsby for each page of the website

- **`/pagesComponents`**: Contains the Rescript components for the each entry point in **`/pages`**

- **`/service`**: Contains generell Rescript functions that are not React components or functions directly related to them

- **`/styles`**: Contains css styling files

