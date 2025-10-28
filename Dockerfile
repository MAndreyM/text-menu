# Мульти-стадийный Dockerfile с doctest, Doxygen, Ninja
FROM registry.red-soft.ru/ubi8/ubi as base

LABEL maintainer="mam28.andr@yandex.ru"
LABEL description="C++ Application with doctest, Doxygen, Ninja"
LABEL version="1.0"

WORKDIR /project

# Development стадия с полным набором инструментов
FROM base as dev

# Development зависимости + doctest, Doxygen, Ninja
RUN dnf update -y && \
    dnf install -y \
    gcc gcc-c++ \
    gdb \
    cmake \
    ninja-build \
    git \
    vim \
    doxygen \
    graphviz \
    clang-tools-extra \
    && dnf clean all

# Устанавливаем doctest (header-only)
#RUN mkdir -p /usr/local/include/doctest && \
#    curl -L https://github.com/doctest/doctest/releases/download/v2.4.11/doctest.h \
#    -o /usr/local/include/doctest/doctest.h

# Копируем исходный код
COPY . .

# Сборка проекта с Ninja
RUN mkdir -p build #&& \
#    cd build && \
#    cmake -G Ninja .. -DCMAKE_BUILD_TYPE=Debug && \
#    ninja

CMD ["/bin/bash"]

# Builder стадия
FROM base as builder

RUN dnf update -y && \
    dnf install -y gcc gcc-c++ cmake ninja-build git doxygen && \
    dnf clean all

# Устанавливаем doctest для сборки тестов
#RUN mkdir -p /usr/local/include/doctest && \
#    curl -L https://github.com/doctest/doctest/releases/download/v2.4.11/doctest.h \
#    -o /usr/local/include/doctest/doctest.h

COPY . .
RUN mkdir -p build && \
    cd build && \
    cmake -G Ninja .. -DCMAKE_BUILD_TYPE=Release && \
    ninja

# Production стадия (минимальная)
FROM base as prod

RUN dnf update -y && dnf install -y libstdc++ && dnf clean all

WORKDIR /app
COPY --from=builder /project/build/src/text-menu .

RUN groupadd -r appuser && useradd -r -g appuser appuser && \
    chown appuser:appuser /app/text-menu

USER appuser

CMD ["./text-menu"]

# Дополнительная стадия для документации
FROM base as docs

RUN dnf update -y && \
    dnf install -y doxygen graphviz make && \
    dnf clean all

COPY . .
WORKDIR /docs

CMD ["doxygen", "Doxyfile"]
