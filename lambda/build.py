import os
import shutil
import time

from jinja2 import Environment, FileSystemLoader

INPUT_DIR = 'site'
OUTPUT_DIR = 'build'
BLOG_DIR = os.path.join(OUTPUT_DIR, 'blog')

# Generate build_ts to prevent css & js caching
BUILD_TS = int(time.time())

# Set up Jinja2 environment
template_dir = os.path.join(INPUT_DIR, 'templates')
env = Environment(loader=FileSystemLoader(template_dir))

# Define pages to generate from templates
pages_data = [
    {
        'template_name': 'index.html',
        'output_dir': '',
        'context': {}
    },
    {
        'template_name': 'blog.html',
        'output_dir': 'blog',
        'context': {}
    },
    {
        'template_name': 'media.html',
        'output_dir': 'books',
        'context': {}
    },
    {
        'template_name': 'media.html',
        'output_dir': 'movies',
        'context': {}
    },
    {
        'template_name': 'about.html',
        'output_dir': 'about',
        'context': {}
    },
]

blogs_data = [
    {
        'template_name': 'post.html',
        'output_dir': 'japanese',
        'context': {}
    },
]

# Clear previous build
shutil.rmtree(OUTPUT_DIR)

# Render and save each page
for page in pages_data:
    template = env.get_template(page['template_name'])
    rendered_html = template.render(**page['context'], build_ts=BUILD_TS)

    page_dir = os.path.join(OUTPUT_DIR, page['output_dir'])
    os.makedirs(page_dir)
    output_path = os.path.join(page_dir, 'index.html')
    with open(output_path, 'w') as f:
        f.write(rendered_html)
    print(f"Generated {output_path}")

# Render and save each blog post
for blog in blogs_data:
    template = env.get_template(blog['template_name'])
    rendered_html = template.render(**blog['context'], build_ts=BUILD_TS)

    page_dir = os.path.join(BLOG_DIR, blog['output_dir'])
    os.makedirs(page_dir)
    output_path = os.path.join(page_dir, 'index.html')
    with open(output_path, 'w') as f:
        f.write(rendered_html)
    print(f"Generated {output_path}")

source = os.path.join(INPUT_DIR, 'static')
destination = os.path.join(OUTPUT_DIR, 'static')
shutil.copytree(source, destination)
print(f"Generated {destination}")
