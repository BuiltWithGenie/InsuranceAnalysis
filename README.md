# Insurance data analysis

An app to analyze and browse insurance data. First page shows tables with contract data, which can be grouped and aggregated by columns. Second page shows a Year event loss table.

![CleanShot 2024-09-30 at 16 42 28](https://github.com/user-attachments/assets/abea3c1d-c689-4f52-9e59-7bd2524b2f46)


## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`
