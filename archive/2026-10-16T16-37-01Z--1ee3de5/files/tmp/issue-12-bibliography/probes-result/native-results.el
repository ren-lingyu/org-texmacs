(:emacs "31.1" :org "9.8.10" :results
	((string "@string{word={Native}}\n@book{key,title=word}"
		 (native-control (version "2.1.5")
				 (document
				  (bib-entry "book" "key"
					     (document
					      (bib-field "title"
							 "Native"))))
				 (bib-list "1"
					   (document
					    (concat (bibitem* "1")
						    (label "probe-key")
						    (with "font-shape"
							  "italic"
							  "Native")
						    "." (newblock))))))
	 (concat "@book{key,title={Native} # { Title}}"
		 (native-control (version "2.1.5")
				 (document
				  (bib-entry "book" "key"
					     (document
					      (bib-field "title"
							 "Native Title"))))
				 (bib-list "1"
					   (document
					    (concat (bibitem* "1")
						    (label "probe-key")
						    (with "font-shape"
							  "italic"
							  "Native Title")
						    "." (newblock))))))
	 (preamble
	  "@preamble{\"Native preamble\"}\n@book{key,title={Book}}"
	  (native-control (version "2.1.5")
			  (document
			   (bib-entry "book" "key"
				      (document
				       (bib-field "title" "Book"))))
			  (bib-list "1"
				    (document
				     (concat (bibitem* "1")
					     (label "probe-key")
					     (with "font-shape"
						   "italic" "Book")
					     "." (newblock))))))
	 (online
	  "@online{key,title={Online},url={https://example.org}}"
	  (native-control (version "2.1.5")
			  (document
			   (bib-entry "online" "key"
				      (document
				       (bib-field "title" "Online")
				       (bib-field "url"
						  (slink
						   "https://example.org")))))
			  (bib-list "1"
				    (document
				     (concat (bibitem* "1")
					     (label "probe-key")
					     "Online." (newblock))))))
	 (unknown "@unknown{key,title={Unknown}}"
		  (native-control (version "2.1.5")
				  (document
				   (bib-entry "unknown" "key"
					      (document
					       (bib-field "title"
							  "Unknown"))))
				  (bib-list "1"
					    (document
					     (concat (bibitem* "1")
						     (label
						      "probe-key")
						     "Unknown."
						     (newblock))))))
	 (undefined "@book{key,title=UNDEFINED}"
		    (native-control (version "2.1.5")
				    (document
				     (bib-entry "book" "key"
						(document
						 (bib-field "title"
							    "UNDEFINED"))))
				    (bib-list "1"
					      (document
					       (concat (bibitem* "1")
						       (label
							"probe-key")
						       (with
							"font-shape"
							"italic"
							"UNDEFINED")
						       "." (newblock))))))
	 (defined
	  "@string{UNDEFINED={Defined}}\n@book{key,title=UNDEFINED}"
	  (native-control (version "2.1.5")
			  (document
			   (bib-entry "book" "key"
				      (document
				       (bib-field "title" "Defined"))))
			  (bib-list "1"
				    (document
				     (concat (bibitem* "1")
					     (label "probe-key")
					     (with "font-shape"
						   "italic" "Defined")
					     "." (newblock))))))
	 (after-defined "@book{key,title=UNDEFINED}"
			(native-control (version "2.1.5")
					(document
					 (bib-entry "book" "key"
						    (document
						     (bib-field
						      "title"
						      "UNDEFINED"))))
					(bib-list "1"
						  (document
						   (concat
						    (bibitem* "1")
						    (label "probe-key")
						    (with "font-shape"
							  "italic"
							  "UNDEFINED")
						    "." (newblock))))))
	 (duplicate-key "@book{key,title={A}}\n@book{key,title={B}}"
			(native-control (version "2.1.5")
					(document
					 (bib-entry "book" "key"
						    (document
						     (bib-field
						      "title" "A")))
					 (bib-entry "book" "key"
						    (document
						     (bib-field
						      "title" "B"))))
					(bib-list "2"
						  (document
						   (concat
						    (bibitem* "1")
						    (label "probe-key")
						    (with "font-shape"
							  "italic" "A")
						    "." (newblock))
						   (concat
						    (bibitem* "2")
						    (label "probe-key")
						    (with "font-shape"
							  "italic" "B")
						    "." (newblock))))))
	 (duplicate-field "@book{key,title={A},TITLE={B}}"
			  (native-control (version "2.1.5")
					  (document
					   (bib-entry "book" "key"
						      (document
						       (bib-field
							"title" "A")
						       (bib-field
							"title" "B"))))
					  (bib-list "1"
						    (document
						     (concat
						      (bibitem* "1")
						      (label
						       "probe-key")
						      (with
						       "font-shape"
						       "italic" "A")
						      "." (newblock))))))
	 (malformed "@book{key,title={Missing"
		    (native-control (version "2.1.5")
				    (document
				     (bib-entry "book" "key"
						(document
						 (bib-field "title"
							    "Missing"))))
				    (bib-list "1"
					      (document
					       (concat (bibitem* "1")
						       (label
							"probe-key")
						       (with
							"font-shape"
							"italic"
							"Missing")
						       "." (newblock))))))
	 (garbage "unparsed trailing text"
		  (native-control (version "2.1.5")
				  (document (bib-comment (document)))
				  (bib-list "0" (document))))
	 (empty ""
		(native-control (version "2.1.5") ""
				(bib-list "0" (document))))
	 (child "@book{child,title={Child},crossref={parent}}"
		(native-control (version "2.1.5")
				(document
				 (bib-entry "book" "child"
					    (document
					     (bib-field "title"
							"Child")
					     (bib-field "crossref"
							"parent"))))
				(bib-list "1"
					  (document
					   (concat (bibitem* "1")
						   (label
						    "probe-child")
						   (with "font-shape"
							 "italic"
							 "Child")
						   ". " (newblock)
						   (localize "In ")
						   (cite "parent") "."
						   (newblock))))))
	 (child-parent
	  "@book{child,title={Child},crossref={parent}}\n@book{parent,title={Parent}}"
	  (native-control (version "2.1.5")
			  (document
			   (bib-entry "book" "child"
				      (document
				       (bib-field "title" "Child")
				       (bib-field "crossref" "parent")))
			   (bib-entry "book" "parent"
				      (document
				       (bib-field "title" "Parent"))))
			  (bib-list "2"
				    (document
				     (concat (bibitem* "1")
					     (label "probe-child")
					     (with "font-shape"
						   "italic" "Child")
					     ". " (newblock)
					     (localize "In ")
					     (cite "parent") "."
					     (newblock))
				     (concat (bibitem* "2")
					     (label "probe-parent")
					     (with "font-shape"
						   "italic" "Parent")
					     "." (newblock))))))
	 (xdata "@book{key,title={Book},xdata={missing}}"
		(native-control (version "2.1.5")
				(document
				 (bib-entry "book" "key"
					    (document
					     (bib-field "title" "Book")
					     (bib-field "xdata"
							"missing"))))
				(bib-list "1"
					  (document
					   (concat (bibitem* "1")
						   (label "probe-key")
						   (with "font-shape"
							 "italic"
							 "Book")
						   "." (newblock))))))))
