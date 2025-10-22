#!/bin/bash
set -e

# Source common utilities
source "$(dirname "$0")/../lib/common.sh"

install_chunkhound() {
    print_info "Installing Chunkhound..."

    # Ensure Homebrew is available (uv is installed via brew)
    ensure_brew

    # Check if uv is available
    if ! command -v uv &>/dev/null; then
        print_error "uv is not installed. Please install uv first (it's in Brewfile.basic)"
        print_warning "Run: brew install uv"
        exit 1
    fi

    # Install chunkhound using uv
    print_info "Installing chunkhound via uv tool install..."
    if uv tool install chunkhound; then
        print_success "Chunkhound installed successfully!"
        print_info "Chunkhound is now available globally"
        echo ""

        # Check for Ollama and offer to pull embedding model
        if command -v ollama &>/dev/null; then
            print_info "Ollama detected! For local Ukrainian-supporting embeddings, pull:"
            print_warning "  ollama pull jeffh/intfloat-multilingual-e5-large-instruct:f16"
            echo ""
            print_info "Then create .chunkhound.json in your project with:"
            echo '  {"embedding": {"provider": "openai", "base_url": "http://localhost:11434/v1",'
            echo '   "model": "jeffh/intfloat-multilingual-e5-large-instruct:f16", "api_key": "dummy-key"}}'
            echo ""
            print_info "Note: The instruct version is optimized for RAG/search queries"
        else
            print_warning "Ollama not found. Install it for local embeddings (Brewfile.macos)"
            print_info "Or configure cloud provider in .chunkhound.json"
        fi

        echo ""
        print_info "To index a project: chunkhound index /path/to/project"
        print_info "To use as MCP server: add to .mcp.json in your project"
    else
        print_error "Failed to install chunkhound"
        exit 1
    fi
}

# Main execution
main() {
    install_chunkhound
}

main "$@"