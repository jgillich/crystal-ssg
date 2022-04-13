# Spooky

Static site generator in Crystal. Work in progress, do not use.

https://jinja.palletsprojects.com/en/3.0.x/templates/

## Why another static site generator?

Mkdocs is the perfect SSG for documentation, except for one major flaw: It's slow. Large sites take >30 seconds to build. Most other SSGs also don't scale well.

Hugo is very fast, but it lacks the simplicity of mkdocs because pages in Hugo must have frontmatter.

Plus, this is a fun project to work on. Yes, I am [not the first one](https://jamstack.org/generators/) to feel this way. =)

## Design

### Site

A `site.yaml` file must be the root of a site. It may be empty.

### Pages

Pages are stored in the `/pages` directory. The two supported page types are markdown and HTML.

The markdown content type contains standard markdown plus optional frontmatter in YAML. No templating is supported in markdown pages.

HTML pages support full Jinja2 templating. They may extend and import files in the `/templates` directory, but they cannot be imported themselves.

Pages named `index` are treated as the root of a folder. `/foo/index.md` is the same as `/foo.md`.

### Templates

Templates are stored in the `/templates` directory. They use the Jinja2 templating syntax.

Templates used to render pages are called layouts. Layouts must be named `_layout.html`.

The layout to use is determined by the page's file path. A page at `/pages/foo/bar/baz.md` will look for a layouts at the following locations:

1. `/templates/foo/bar/_layout.md`
1. `/templates/foo/_layout.html`
1. `/templates/_layout.html`

The layout choice cannot be overriden via frontmatter.

### Static

Static files are stored in the `/static` directory. They are copied to the output as-is (unless modified by plugins, see below)

### Plugins

Plugins are used to extend core functionality. Theu use various hooks to customize the build step for pages, static files and more.
Plugins are written in Crystal and must be compiled into the binary. There are a number of built-in plugins for common use-cases such as PostCSS compilation.

### Themes

Themes are a external collection of templates and static files. They can be installed by adding an entry to `site.yaml`:

```yaml
themes:
  - name: material
    git: https://github.com/foo/material.git
```

Theme files are overridden by local files with the same name. There is a built-in default theme based on Tailwind CSS.
Themes may act as component libraries by prefixing their files,

A site can use multiple themes. Themes that act as component libraries are encouraged to prefix their templates with the theme name.
