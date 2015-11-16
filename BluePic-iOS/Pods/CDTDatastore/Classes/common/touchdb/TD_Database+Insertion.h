//
//  TD_Database+Insertion.h
//  TouchDB
//
//  Created by Jens Alfke on 1/18/12.
//  Copyright (c) 2012 Couchbase, Inc. All rights reserved.
//
//  Modifications for this distribution by Cloudant, Inc., Copyright (c) 2014 Cloudant, Inc.
//

#import "TD_Database.h"

@protocol TD_ValidationContext;

/** Validation block, used to approve revisions being added to the database. */
typedef BOOL (^TD_ValidationBlock)(TD_Revision* newRevision, id<TD_ValidationContext> context);

@interface TD_Database (Insertion)

+ (BOOL)isValidDocumentID:(NSString*)str;

+ (NSString*)generateDocumentID;

/** Stores a new (or initial) revision of a document. This is what's invoked by a PUT or POST. As
   with those, the previous revision ID must be supplied when necessary and the call will fail if it
   doesn't match.
    @param revision  The revision to add. If the docID is nil, a new UUID will be assigned. Its
   revID must be nil. It must have a JSON body.
    @param prevRevID  The ID of the revision to replace (same as the "?rev=" parameter to a PUT), or
   nil if this is a new document.
    @param allowConflict  If NO, an error status kTDStatusConflict will be returned if the insertion
   would create a conflict, i.e. if the previous revision already has a child.
    @param status  On return, an HTTP status code indicating success or failure.
    @return  A new TD_Revision with the docID, revID and sequence filled in (but no body). */
- (TD_Revision*)putRevision:(TD_Revision*)revision
             prevRevisionID:(NSString*)prevRevID
              allowConflict:(BOOL)allowConflict
                     status:(TDStatus*)outStatus;

/** Inserts an already-existing revision replicated from a remote database. It must already have a
 * revision ID. This may create a conflict! The revision's history must be given; ancestor revision
 * IDs that don't already exist locally will create phantom revisions with no content. */
- (TDStatus)forceInsert:(TD_Revision*)rev revisionHistory:(NSArray*)history source:(NSURL*)source;

/** Parses the _revisions dict from a document into an array of revision ID strings */
+ (NSArray*)parseCouchDBRevisionHistory:(NSDictionary*)docProperties;

/** Define or clear a named document validation function.  */
- (void)defineValidation:(NSString*)validationName asBlock:(TD_ValidationBlock)validationBlock;
- (TD_ValidationBlock)validationNamed:(NSString*)validationName;

/** Compacts the database storage by removing the bodies and attachments of obsolete revisions. */
- (TDStatus)compact;

/** Purges specific revisions, which deletes them completely from the local database _without_
   adding a "tombstone" revision. It's as though they were never there.
    @param docsToRevs  A dictionary mapping document IDs to arrays of revision IDs.
    @param outResult  On success will point to an NSDictionary with the same form as docsToRev,
   containing the doc/revision IDs that were actually removed. */
- (TDStatus)purgeRevisions:(NSDictionary*)docsToRevs result:(NSDictionary**)outResult;

/**
 Public method that should be used when you wish to make multiple putRevisions within a single
 database transation via TD_Database -inTransaction:
 */
- (TD_Revision*)putRevision:(TD_Revision*)revToInsert
             prevRevisionID:(NSString*)prevRevId
              allowConflict:(BOOL)allowConflict
                     status:(TDStatus*)outStatus
                   database:(FMDatabase*)db;

@end

typedef BOOL (^TDChangeEnumeratorBlock)(NSString* key, id oldValue, id newValue);

/** Context passed into a TDValidationBlock. */
@protocol TD_ValidationContext <NSObject>
/** The contents of the current revision of the document, or nil if this is a new document. */
@property (readonly) TD_Revision* currentRevision;

/** The type of HTTP status to report, if the validate block returns NO.
    The default value is 403 ("Forbidden"). */
@property TDStatus errorType;

/** The error message to return in the HTTP response, if the validate block returns NO.
    The default value is "invalid document". */
@property (copy) NSString* errorMessage;

/** Returns an array of all the keys whose values are different between the current and new
 * revisions. */
@property (readonly) NSArray* changedKeys;

/** Returns YES if only the keys given in the 'allowedKeys' array have changed; else returns NO and
 * sets a default error message naming the offending key. */
- (BOOL)allowChangesOnlyTo:(NSArray*)allowedKeys;

/** Returns YES if none of the keys given in the 'disallowedKeys' array have changed; else returns
 * NO and sets a default error message naming the offending key. */
- (BOOL)disallowChangesTo:(NSArray*)disallowedKeys;

/** Calls the 'enumerator' block for each key that's changed, passing both the old and new values.
    If the block returns NO, the enumeration stops and sets a default error message, and the method
   returns NO; else the method returns YES. */
- (BOOL)enumerateChanges:(TDChangeEnumeratorBlock)enumerator;

@end
