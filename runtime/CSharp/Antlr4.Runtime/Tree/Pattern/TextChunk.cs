// Copyright (c) Terence Parr, Sam Harwell. All Rights Reserved.
// Licensed under the BSD License. See LICENSE.txt in the project root for license information.

/*
 * Copyright (c) 2012 The ANTLR Project. All rights reserved.
 * Use of this file is governed by the BSD-3-Clause license that
 * can be found in the LICENSE.txt file in the project root.
 */
using System;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Sharpen;

namespace Antlr4.Runtime.Tree.Pattern
{
    /// <summary>
    /// Represents a span of raw text (concrete syntax) between tags in a tree
    /// pattern string.
    /// </summary>
    internal class TextChunk : Chunk
    {
        /// <summary>
        /// This is the backing field for
        /// <see cref="Text()"/>
        /// .
        /// </summary>
        [NotNull]
        private readonly string text;

        /// <summary>
        /// Constructs a new instance of
        /// <see cref="TextChunk"/>
        /// with the specified text.
        /// </summary>
        /// <param name="text">The text of this chunk.</param>
        /// <exception>
        /// IllegalArgumentException
        /// if
        /// <paramref name="text"/>
        /// is
        /// <see langword="null"/>
        /// .
        /// </exception>
        public TextChunk([NotNull] string text)
        {
            if (text == null)
            {
                throw new ArgumentException("text cannot be null");
            }
            this.text = text;
        }

        /// <summary>Gets the raw text of this chunk.</summary>
        /// <returns>The text of the chunk.</returns>
        public string Text
        {
            get
            {
                return text;
            }
        }

        /// <summary>
        /// <inheritDoc/>
        /// <p>The implementation for
        /// <see cref="TextChunk"/>
        /// returns the result of
        /// <see cref="Text()"/>
        /// in single quotes.</p>
        /// </summary>
        public override string ToString()
        {
            return "'" + text + "'";
        }
    }
}
