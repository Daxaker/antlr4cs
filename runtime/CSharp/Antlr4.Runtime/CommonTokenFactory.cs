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

namespace Antlr4.Runtime
{
    /// <summary>
    /// This default implementation of
    /// <see cref="ITokenFactory"/>
    /// creates
    /// <see cref="CommonToken"/>
    /// objects.
    /// </summary>
    public class CommonTokenFactory : ITokenFactory
    {
        /// <summary>
        /// The default
        /// <see cref="CommonTokenFactory"/>
        /// instance.
        /// <p>
        /// This token factory does not explicitly copy token text when constructing
        /// tokens.</p>
        /// </summary>
        public static readonly ITokenFactory Default = new Antlr4.Runtime.CommonTokenFactory();

        /// <summary>
        /// Indicates whether
        /// <see cref="CommonToken.Text(string)"/>
        /// should be called after
        /// constructing tokens to explicitly set the text. This is useful for cases
        /// where the input stream might not be able to provide arbitrary substrings
        /// of text from the input after the lexer creates a token (e.g. the
        /// implementation of
        /// <see cref="ICharStream.GetText(Antlr4.Runtime.Misc.Interval)"/>
        /// in
        /// <see cref="UnbufferedCharStream"/>
        /// throws an
        /// <see cref="System.NotSupportedException"/>
        /// ). Explicitly setting the token text
        /// allows
        /// <see cref="IToken.Text()"/>
        /// to be called at any time regardless of the
        /// input stream implementation.
        /// <p>
        /// The default value is
        /// <see langword="false"/>
        /// to avoid the performance and memory
        /// overhead of copying text for every token unless explicitly requested.</p>
        /// </summary>
        protected internal readonly bool copyText;

        /// <summary>
        /// Constructs a
        /// <see cref="CommonTokenFactory"/>
        /// with the specified value for
        /// <see cref="copyText"/>
        /// .
        /// <p>
        /// When
        /// <paramref name="copyText"/>
        /// is
        /// <see langword="false"/>
        /// , the
        /// <see cref="Default"/>
        /// instance
        /// should be used instead of constructing a new instance.</p>
        /// </summary>
        /// <param name="copyText">
        /// The value for
        /// <see cref="copyText"/>
        /// .
        /// </param>
        public CommonTokenFactory(bool copyText)
        {
            this.copyText = copyText;
        }

        /// <summary>
        /// Constructs a
        /// <see cref="CommonTokenFactory"/>
        /// with
        /// <see cref="copyText"/>
        /// set to
        /// <see langword="false"/>
        /// .
        /// <p>
        /// The
        /// <see cref="Default"/>
        /// instance should be used instead of calling this
        /// directly.</p>
        /// </summary>
        public CommonTokenFactory()
            : this(false)
        {
        }

        public virtual CommonToken Create<_T0>(Tuple<_T0> source, int type, string text, int channel, int start, int stop, int line, int charPositionInLine)
            where _T0 : ITokenSource
        {
            CommonToken t = new CommonToken(source, type, channel, start, stop);
            t.Line = line;
            t.Column = charPositionInLine;
            if (text != null)
            {
                t.Text = text;
            }
            else
            {
                if (copyText && source.Item2 != null)
                {
                    t.Text = source.Item2.GetText(Interval.Of(start, stop));
                }
            }
            return t;
        }

        public virtual CommonToken Create(int type, string text)
        {
            return new CommonToken(type, text);
        }
    }
}
