cmake_minimum_required(VERSION 3.10)

project(template)

find_package(Marp REQUIRED)

marp_slides(slides
            INPUT slides.md
)
